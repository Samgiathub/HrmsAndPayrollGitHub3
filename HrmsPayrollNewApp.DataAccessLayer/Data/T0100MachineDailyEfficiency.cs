using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0100MachineDailyEfficiency
{
    public decimal EfficiencyId { get; set; }

    public decimal CmpId { get; set; }

    public DateTime ForDate { get; set; }

    public string? MachineId { get; set; }

    public decimal ShiftId { get; set; }

    public decimal AssignedEmpId { get; set; }

    public decimal AlternateEmpId { get; set; }

    public decimal? Efficiency { get; set; }

    public decimal? SegmentId { get; set; }

    public string? WeaverFlag { get; set; }
}
