using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0040MachineMaster
{
    public decimal MachineId { get; set; }

    public decimal CmpId { get; set; }

    public string MachineName { get; set; } = null!;

    public string MachineCode { get; set; } = null!;

    public string? MachineType { get; set; }

    public string? Remarks { get; set; }

    public virtual ICollection<T0040MachineEfficiencyMaster> T0040MachineEfficiencyMasters { get; set; } = new List<T0040MachineEfficiencyMaster>();
}
