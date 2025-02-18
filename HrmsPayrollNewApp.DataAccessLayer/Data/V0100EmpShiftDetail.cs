using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0100EmpShiftDetail
{
    public decimal ShiftTranId { get; set; }

    public decimal EmpId { get; set; }

    public decimal CmpId { get; set; }

    public decimal ShiftId { get; set; }

    public DateTime ForDate { get; set; }

    public decimal? ShiftType { get; set; }

    public string? EmpFullName { get; set; }

    public string ShiftName { get; set; } = null!;

    public string EmpFirstName { get; set; } = null!;

    public string? BranchName { get; set; }

    public decimal EmpCode { get; set; }

    public decimal BranchId { get; set; }

    public int? Month { get; set; }

    public int? Year { get; set; }

    public string? AlphaEmpCode { get; set; }

    public decimal? VerticalId { get; set; }

    public decimal? SubVerticalId { get; set; }

    public decimal? DeptId { get; set; }
}
