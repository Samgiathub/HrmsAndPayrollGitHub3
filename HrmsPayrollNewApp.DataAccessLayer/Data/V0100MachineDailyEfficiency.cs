using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0100MachineDailyEfficiency
{
    public decimal EfficiencyId { get; set; }

    public decimal EmpId { get; set; }

    public decimal CmpId { get; set; }

    public DateTime ForDate { get; set; }

    public string? MachineId { get; set; }

    public decimal ShiftId { get; set; }

    public decimal? Efficiency { get; set; }

    public string? MachineName { get; set; }

    public string? MachineType { get; set; }

    public string? AssignedEmpCode { get; set; }

    public string? AssignedEmpName { get; set; }

    public string? AssignedEmpFullName { get; set; }

    public decimal AlternateEmpId { get; set; }

    public string? AlternateEmpCode { get; set; }

    public string? AlternateEmpName { get; set; }

    public string? AlternateEmpFullName { get; set; }

    public string? WeavingFlag { get; set; }

    public string ShiftName { get; set; } = null!;

    public decimal? SegmentId { get; set; }
}
