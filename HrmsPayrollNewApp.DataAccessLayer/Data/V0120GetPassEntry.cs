using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0120GetPassEntry
{
    public DateTime? FromDate { get; set; }

    public DateTime? ToDate { get; set; }

    public string? LeaveAssignAs { get; set; }

    public decimal? LeavePeriod { get; set; }

    public decimal? LeaveApprovalId { get; set; }

    public string? ApprovalStatus { get; set; }

    public string? EmpFirstName { get; set; }

    public DateTime? ApprovalDate { get; set; }

    public string? ApplicationCode { get; set; }

    public decimal? CmpId { get; set; }

    public DateTime? ApplicationDate { get; set; }

    public string? LeaveName { get; set; }

    public string? LeavePaidUnpaid { get; set; }

    public decimal? LeaveMin { get; set; }

    public decimal? LeaveMax { get; set; }

    public decimal? LeaveStatus { get; set; }

    public decimal? LeaveApplicable { get; set; }

    public decimal? LeaveNoticePeriod { get; set; }

    public decimal LeaveApplicationId { get; set; }

    public decimal? LeaveId { get; set; }

    public string? LeaveReason { get; set; }

    public decimal? RowId { get; set; }

    public string? EmpFullName { get; set; }

    public decimal? GrdId { get; set; }

    public decimal? DeptId { get; set; }

    public DateTime? DateOfJoin { get; set; }

    public decimal? EmpCode { get; set; }

    public string? OtherEmail { get; set; }

    public string? MobileNo { get; set; }

    public decimal? EmpId { get; set; }

    public string? SEmpFullName { get; set; }

    public string? SOtherEmail { get; set; }

    public decimal? SEmpId { get; set; }

    public string? ApprovalComments { get; set; }

    public decimal? BranchId { get; set; }

    public decimal? DesigId { get; set; }

    public string? LeaveType { get; set; }

    public string? AlphaEmpCode { get; set; }

    public int MCancelWoHo { get; set; }

    public DateTime? HalfLeaveDate { get; set; }

    public string LeaveOutTime { get; set; } = null!;

    public string LeaveInTime { get; set; } = null!;

    public string LeaveActualOutTime { get; set; } = null!;

    public string LeaveActualInTime { get; set; } = null!;

    public string? Photo { get; set; }

    public DateTime? LeaveActualOutDate { get; set; }

    public DateTime? LeaveActualInDate { get; set; }

    public decimal? VerticalId { get; set; }

    public decimal? SubVerticalId { get; set; }
}
