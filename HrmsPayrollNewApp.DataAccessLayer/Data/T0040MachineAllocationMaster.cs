using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0040MachineAllocationMaster
{
    public decimal AllocationId { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public decimal? ShiftId { get; set; }

    public DateTime? EffectiveDate { get; set; }

    public string? MachineId { get; set; }
}
