package models

type CPUInfo struct {
	Cores   int    `json:"cores"`
	Threads int    `json:"threads"`
	Model   string `json:"model"`
}

type GPUInfo struct {
	Name  string `json:"name"`
	Count int    `json:"count"`
}

type MemoryInfo struct {
	TotalGB float64 `json:"total_gb"`
}

type DiskInfo struct {
	TotalGB float64 `json:"total_gb"`
}

type OSInfo struct {
	System  string `json:"system"`
	Release string `json:"release"`
	Version string `json:"version"`
}

type StaticInfo struct {
	CPU    CPUInfo    `json:"cpu"`
	GPU    GPUInfo    `json:"gpu"`
	Memory MemoryInfo `json:"memory"`
	Disk   DiskInfo   `json:"disk"`
	OS     OSInfo     `json:"os"`
}

type AggregatedMetrics struct {
	CPU        []float64   `json:"cpu"`
	Mem        []float64   `json:"mem"`
	Disk       []float64   `json:"disk"`
	DiskRead   []uint64    `json:"disk_read"`
	DiskWrite  []uint64    `json:"disk_write"`
	NetSent    []uint64    `json:"net_sent"`
	NetRecv    []uint64    `json:"net_recv"`
	GPULoad    []*float64  `json:"gpu_load"`
	GPUMemUsed []*float64  `json:"gpu_mem_used"`
	GPUTemp    []*float64  `json:"gpu_temp"`
}

type SystemMetricsResponse struct {
	Static  StaticInfo        `json:"static"`
	Metrics AggregatedMetrics `json:"metrics"`
}
