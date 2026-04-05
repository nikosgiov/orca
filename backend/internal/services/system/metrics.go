package system

import (
	"fmt"
	"os/exec"
	"runtime"
	"strconv"
	"strings"
	"sync"
	"time"

	"go_backend/internal/models"

	"github.com/shirou/gopsutil/v3/cpu"
	"github.com/shirou/gopsutil/v3/disk"
	"github.com/shirou/gopsutil/v3/host"
	"github.com/shirou/gopsutil/v3/mem"
	"github.com/shirou/gopsutil/v3/net"
)

type GPUMetrics struct {
	Load     float64 `json:"load"`
	MemUsed  float64 `json:"mem_used"`
	MemTotal float64 `json:"mem_total"`
	Temp     float64 `json:"temp"`
}

type MetricsPoint struct {
	CPU       float64
	Mem       float64
	Disk      float64
	DiskRead  uint64
	DiskWrite uint64
	NetSent   uint64
	NetRecv   uint64
	GPU       *GPUMetrics
}

func getGPUStats() *GPUMetrics {
	cmd := exec.Command("nvidia-smi", "--query-gpu=utilization.gpu,memory.used,memory.total,temperature.gpu", "--format=csv,noheader,nounits")
	output, err := cmd.Output()
	if err != nil {
		fmt.Printf("GPU STATS ERROR: Failed to execute nvidia-smi: %v. Output: %s\n", err, string(output))
		return nil
	}

	lines := strings.Split(strings.TrimSpace(string(output)), "\n")
	if len(lines) == 0 || lines[0] == "" {
		return nil
	}

	var totalLoad, totalMemUsed, totalMemTotal, totalTemp float64
	var count float64

	for _, line := range lines {
		parts := strings.Split(strings.TrimSpace(line), ",")
		if len(parts) < 4 {
			continue
		}

		load, _ := strconv.ParseFloat(strings.TrimSpace(parts[0]), 64)
		memUsed, _ := strconv.ParseFloat(strings.TrimSpace(parts[1]), 64)
		memTotal, _ := strconv.ParseFloat(strings.TrimSpace(parts[2]), 64)
		temp, _ := strconv.ParseFloat(strings.TrimSpace(parts[3]), 64)

		totalLoad += load
		totalMemUsed += memUsed
		totalMemTotal += memTotal
		totalTemp += temp
		count++
	}

	if count == 0 {
		return nil
	}

	return &GPUMetrics{
		Load:     (totalLoad / count) / 100.0,
		MemUsed:  totalMemUsed,
		MemTotal: totalMemTotal,
		Temp:     totalTemp / count,
	}
}


type MetricsCollector struct {
	mu        sync.RWMutex
	metrics1s []MetricsPoint
	metrics1m []MetricsPoint
	metrics1h []MetricsPoint
	counter   int
}

var GlobalCollector = NewCollector()

func NewCollector() *MetricsCollector {
	return &MetricsCollector{
		metrics1s: []MetricsPoint{},
		metrics1m: []MetricsPoint{},
		metrics1h: []MetricsPoint{},
	}
}

func (mc *MetricsCollector) Start() {
	ticker := time.NewTicker(1 * time.Second)
	go func() {
		for range ticker.C {
			mc.Collect()
		}
	}()
}

func (mc *MetricsCollector) Collect() {
	c, _ := cpu.Percent(0, false)
	m, _ := mem.VirtualMemory()
	d, _ := disk.Usage("/")
	io, _ := disk.IOCounters()
	netIO, _ := net.IOCounters(false)

	var read, write uint64
	if len(io) > 0 {
		for _, stat := range io {
			read += stat.ReadBytes
			write += stat.WriteBytes
		}
	}

	var sent, recv uint64
	if len(netIO) > 0 {
		sent = netIO[0].BytesSent
		recv = netIO[0].BytesRecv
	}

	var cpuVal float64
	if len(c) > 0 {
		cpuVal = c[0]
	}

	point := MetricsPoint{
		CPU:       cpuVal,
		Mem:       m.UsedPercent,
		Disk:      d.UsedPercent,
		DiskRead:  read,
		DiskWrite: write,
		NetSent:   sent,
		NetRecv:   recv,
		GPU:       getGPUStats(),
	}

	// Alert on high resource usage thresholds continuously
	GlobalResourceMonitor.CheckAndAlert(point)

	mc.mu.Lock()
	defer mc.mu.Unlock()

	mc.metrics1s = append(mc.metrics1s, point)
	if len(mc.metrics1s) > 60 {
		mc.metrics1s = mc.metrics1s[1:]
	}

	mc.counter++

	if mc.counter%60 == 0 {
		agg := mc.aggregate(mc.metrics1s)
		mc.metrics1m = append(mc.metrics1m, agg)
		if len(mc.metrics1m) > 360 {
			mc.metrics1m = mc.metrics1m[1:]
		}
	}

	if mc.counter%3600 == 0 {
		var list []MetricsPoint
		if len(mc.metrics1m) >= 60 {
			list = mc.metrics1m[len(mc.metrics1m)-60:]
		} else {
			list = mc.metrics1m
		}
		agg := mc.aggregate(list)
		mc.metrics1h = append(mc.metrics1h, agg)
		if len(mc.metrics1h) > 24 {
			mc.metrics1h = mc.metrics1h[1:]
		}
	}
}

func (mc *MetricsCollector) aggregate(source []MetricsPoint) MetricsPoint {
	if len(source) == 0 {
		return MetricsPoint{}
	}
	var c, m, d float64
	var dr, dw, ns, nr uint64
	var totalLoad, totalMemUsed, totalMemTotal, totalTemp float64
	var gpuCount int

	for _, p := range source {
		c += p.CPU
		m += p.Mem
		d += p.Disk
		dr += p.DiskRead
		dw += p.DiskWrite
		ns += p.NetSent
		nr += p.NetRecv

		if p.GPU != nil {
			totalLoad += p.GPU.Load
			totalMemUsed += p.GPU.MemUsed
			totalMemTotal += p.GPU.MemTotal
			totalTemp += p.GPU.Temp
			gpuCount++
		}
	}

	l := float64(len(source))
	var aggGPU *GPUMetrics
	if gpuCount > 0 {
		fl := float64(gpuCount)
		aggGPU = &GPUMetrics{
			Load:     totalLoad / fl,
			MemUsed:  totalMemUsed / fl,
			MemTotal: totalMemTotal / fl,
			Temp:     totalTemp / fl,
		}
	}

	return MetricsPoint{
		CPU:       c / l,
		Mem:       m / l,
		Disk:      d / l,
		DiskRead:  uint64(float64(dr) / l),
		DiskWrite: uint64(float64(dw) / l),
		NetSent:   uint64(float64(ns) / l),
		NetRecv:   uint64(float64(nr) / l),
		GPU:       aggGPU,
	}
}


func GetStaticInfo() models.StaticInfo {
	vm, _ := mem.VirtualMemory()
	du, _ := disk.Usage("/")
	hi, _ := host.Info()
	cpuCount, _ := cpu.Counts(false)
	logicalCount, _ := cpu.Counts(true)
	cpuInfo, _ := cpu.Info()

	cpuModel := "Unknown"
	if len(cpuInfo) > 0 {
		cpuModel = cpuInfo[0].ModelName
	}

	gpuName := "N/A"
	gpuCount := 0
	cmd := exec.Command("nvidia-smi", "--query-gpu=name", "--format=csv,noheader")
	if out, err := cmd.Output(); err == nil {
		lines := strings.Split(strings.TrimSpace(string(out)), "\n")
		if len(lines) > 0 && lines[0] != "" {
			gpuName = strings.TrimSpace(lines[0])
			gpuCount = len(lines)
		}
	}

	return models.StaticInfo{
		CPU: models.CPUInfo{
			Cores:   cpuCount,
			Threads: logicalCount,
			Model:   cpuModel,
		},
		GPU: models.GPUInfo{Name: gpuName, Count: gpuCount},
		Memory: models.MemoryInfo{
			TotalGB: float64(vm.Total) / 1e9,
		},
		Disk: models.DiskInfo{
			TotalGB: float64(du.Total) / 1e9,
		},
		OS: models.OSInfo{
			System:  runtime.GOOS,
			Release: hi.OS,
			Version: hi.PlatformVersion,
		},
	}
}

func (mc *MetricsCollector) GetAggregatedMetrics(window string) models.AggregatedMetrics {
	mc.mu.RLock()
	defer mc.mu.RUnlock()

	var source []MetricsPoint
	switch window {
	case "30m":
		source = getRecent(mc.metrics1m, 30)
	case "1h":
		source = getRecent(mc.metrics1m, 60)
	case "6h":
		source = getRecent(mc.metrics1m, 360)
	case "24h":
		source = getRecent(mc.metrics1h, 24)
	default:
		source = getRecent(mc.metrics1s, 15)
	}

	return extractToDict(source)
}

func getRecent(source []MetricsPoint, n int) []MetricsPoint {
	if len(source) <= n {
		return source
	}
	return source[len(source)-n:]
}

func extractToDict(source []MetricsPoint) models.AggregatedMetrics {
	res := models.AggregatedMetrics{
		CPU:       []float64{},
		Mem:       []float64{},
		Disk:      []float64{},
		DiskRead:  []uint64{},
		DiskWrite: []uint64{},
		NetSent:   []uint64{},
		NetRecv:   []uint64{},
		GPULoad:    []*float64{},
		GPUMemUsed: []*float64{},
		GPUTemp:    []*float64{},
	}

	for _, p := range source {
		res.CPU = append(res.CPU, p.CPU)
		res.Mem = append(res.Mem, p.Mem)
		res.Disk = append(res.Disk, p.Disk)
		res.DiskRead = append(res.DiskRead, p.DiskRead)
		res.DiskWrite = append(res.DiskWrite, p.DiskWrite)
		res.NetSent = append(res.NetSent, p.NetSent)
		res.NetRecv = append(res.NetRecv, p.NetRecv)

		if p.GPU != nil {
			l := p.GPU.Load
			mu := p.GPU.MemUsed
			t := p.GPU.Temp
			res.GPULoad = append(res.GPULoad, &l)
			res.GPUMemUsed = append(res.GPUMemUsed, &mu)
			res.GPUTemp = append(res.GPUTemp, &t)
		} else {
			res.GPULoad = append(res.GPULoad, nil)
			res.GPUMemUsed = append(res.GPUMemUsed, nil)
			res.GPUTemp = append(res.GPUTemp, nil)
		}
	}

	return res
}
