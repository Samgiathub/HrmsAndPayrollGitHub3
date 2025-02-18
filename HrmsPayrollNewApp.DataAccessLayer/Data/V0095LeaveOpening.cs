using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0095LeaveOpening
{
    public decimal LeaveOpId { get; set; }

    public decimal EmpId { get; set; }

    public decimal GrdId { get; set; }

    public decimal CmpId { get; set; }

    public decimal LeaveId { get; set; }

    public DateTime ForDate { get; set; }

    public decimal LeaveOpDays { get; set; }

    public string? LeaveName { get; set; }

    public string? LeaveCfType { get; set; }

    public decimal? LeaveNoticePeriod { get; set; }

    public decimal? LeaveApplicable { get; set; }

    public decimal? LeaveMin { get; set; }

    public decimal? LeaveMax { get; set; }

    public decimal? LeaveMinBal { get; set; }

    public decimal? LeaveMaxBal { get; set; }

    public DateTime? DateOfJoin { get; set; }

    public string? EmpFullName { get; set; }

    public string? DefaultShortName { get; set; }

    public decimal? LeaveStatus { get; set; }

    public DateTime? InActiveEffectiveDate { get; set; }

    public string? EmployeeName { get; set; }

    public string GrdName { get; set; } = null!;

    public string? AlphaEmpCode { get; set; }

    public decimal? BranchId { get; set; }

    public decimal? VerticalId { get; set; }

    public decimal? SubVerticalId { get; set; }

    public decimal? DeptId { get; set; }

    public string? LeaveType { get; set; }
}
