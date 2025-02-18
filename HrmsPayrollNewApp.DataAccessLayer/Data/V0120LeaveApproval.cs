using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0120LeaveApproval
{
    public DateTime? FromDate { get; set; }

    public DateTime? ToDate { get; set; }

    public string? LeaveAssignAs { get; set; }

    public decimal? LeavePeriod { get; set; }

    public decimal? LeaveApprovalId { get; set; }

    public string ApprovalStatus { get; set; } = null!;

    public string EmpFirstName { get; set; } = null!;

    public DateTime ApprovalDate { get; set; }

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

    public decimal? LeaveApplicationId { get; set; }

    public decimal? LeaveId { get; set; }

    public string? LeaveReason { get; set; }

    public decimal? RowId { get; set; }

    public string? EmpFullName { get; set; }

    public decimal GrdId { get; set; }

    public decimal? DeptId { get; set; }

    public DateTime DateOfJoin { get; set; }

    public decimal EmpCode { get; set; }

    public string? OtherEmail { get; set; }

    public string? MobileNo { get; set; }

    public decimal EmpId { get; set; }

    public string SEmpFullName { get; set; } = null!;

    public string? SOtherEmail { get; set; }

    public decimal? SEmpId { get; set; }

    public string ApprovalComments { get; set; } = null!;

    public decimal BranchId { get; set; }

    public decimal? DesigId { get; set; }

    public string? LeaveType { get; set; }

    public string? AlphaEmpCode { get; set; }

    public byte MCancelWoHo { get; set; }

    public DateTime? HalfLeaveDate { get; set; }

    public string? LeaveCompOffDates { get; set; }

    public string? DefaultShortName { get; set; }

    public string? WorkEmail { get; set; }

    public decimal? MaxNoOfApplication { get; set; }

    public int? ApplyHourly { get; set; }

    public decimal? VerticalId { get; set; }

    public decimal? SubVerticalId { get; set; }

    public string? LeaveAppDoc { get; set; }

    public string? SeniorEmployee { get; set; }

    public string IsBackdatedApplication { get; set; } = null!;

    public string? SalaryStatus { get; set; }

    public string? CancelDate { get; set; }

    public DateTime? LeaveOutTime { get; set; }

    public DateTime? LeaveInTime { get; set; }

    public byte? HalfPayment { get; set; }

    public byte IsBackdatedApp { get; set; }

    public byte? RulesViolate { get; set; }

    public string? ResponsibleEmployee { get; set; }

    public decimal? SalDateId { get; set; }

    public int BackDatedLeave { get; set; }

    public decimal? ResponsibleEmpId { get; set; }

    public int IsFinalApproved { get; set; }

    public string? BranchName { get; set; }
}
