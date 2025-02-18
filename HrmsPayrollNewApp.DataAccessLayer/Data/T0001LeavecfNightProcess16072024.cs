using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0001LeavecfNightProcess16072024
{
    public decimal LeaveCfId { get; set; }

    public decimal CmpId { get; set; }

    public decimal BranchId { get; set; }

    public decimal? GrdId { get; set; }

    public decimal? DeptId { get; set; }

    public decimal? DesigId { get; set; }

    public decimal? CatId { get; set; }

    public decimal? TypeId { get; set; }

    public decimal? SegmentId { get; set; }

    public decimal? SubBranchId { get; set; }

    public decimal? VerticalId { get; set; }

    public decimal? SubVerticalId { get; set; }

    public decimal EmpId { get; set; }

    public decimal LeaveId { get; set; }

    public DateTime CfForDate { get; set; }

    public DateTime CfFromDate { get; set; }

    public DateTime CfToDate { get; set; }

    public decimal CfPDays { get; set; }

    public decimal CfLeaveDays { get; set; }

    public string CfType { get; set; } = null!;

    public decimal? ExceedCfDays { get; set; }

    public string? LeaveCompOffDates { get; set; }

    public string IsFnf { get; set; } = null!;

    public string? AlphaEmpCode { get; set; }

    public string? EmpFullName { get; set; }

    public string? LeaveName { get; set; }

    public string? NewJoinFlag { get; set; }

    public string? DateOfJoin { get; set; }

    public string? Diff { get; set; }

    public decimal AdvanceLeaveBalance { get; set; }

    public decimal AdvanceLeaveRecoverBalance { get; set; }

    public byte IsAdvanceLeaveBalance { get; set; }

    public byte? Month { get; set; }

    public int? Year { get; set; }
}
