using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0110LeaveApplicationDetailBackupMehul26032022
{
    public decimal CmpId { get; set; }

    public decimal LeaveId { get; set; }

    public DateTime FromDate { get; set; }

    public DateTime ToDate { get; set; }

    public decimal LeavePeriod { get; set; }

    public string LeaveAssignAs { get; set; } = null!;

    public string? LeaveReason { get; set; }

    public decimal RowId { get; set; }

    public decimal LoginId { get; set; }

    public DateTime SystemDate { get; set; }

    public decimal LeaveApplicationId { get; set; }

    public decimal? EmpId { get; set; }

    public decimal? SEmpId { get; set; }

    public DateTime? ApplicationDate { get; set; }

    public string? LeaveName { get; set; }

    public string? LeavePaidUnpaid { get; set; }

    public string? EmpFullName { get; set; }

    public decimal? EmpSuperior { get; set; }

    public string SeniorEmployee { get; set; } = null!;

    public string? ApplicationCode { get; set; }

    public string? ApplicationStatus { get; set; }

    public string? EmpFirstName { get; set; }

    public string? SEmpFirstName { get; set; }

    public string? EmpLeft { get; set; }

    public string? SOtherEmail { get; set; }

    public string? MobileNo { get; set; }

    public decimal? LeaveMin { get; set; }

    public decimal? LeaveMax { get; set; }

    public decimal? LeaveNoticePeriod { get; set; }

    public decimal? LeaveApplicable { get; set; }

    public decimal? LeaveStatus { get; set; }

    public decimal? GrdId { get; set; }

    public DateTime? DateOfJoin { get; set; }

    public decimal? DeptId { get; set; }

    public decimal? DesigId { get; set; }

    public string? SEmpFullName { get; set; }

    public string? OtherEmail { get; set; }

    public decimal? BranchId { get; set; }

    public string? DesigName { get; set; }

    public decimal? SEmpCode { get; set; }

    public string? BranchName { get; set; }

    public decimal? EmpCode { get; set; }

    public string? WorkEmail { get; set; }

    public string? AlphaEmpCode { get; set; }

    public DateTime? HalfLeaveDate { get; set; }

    public string? DefaultShortName { get; set; }

    public byte? IsBackdatedApplication { get; set; }

    public byte? IsResponsibilityPass { get; set; }

    public decimal? ResponsibleEmpId { get; set; }

    public string LeaveAppDoc { get; set; } = null!;

    public string? ApplicationComments { get; set; }

    public int? ApplyHourly { get; set; }

    public byte? CanApplyFraction { get; set; }

    public DateTime? LeaveOutTime { get; set; }

    public DateTime? LeaveInTime { get; set; }

    public string? LeaveType { get; set; }

    public decimal NightHalt { get; set; }

    public int? AllowNightHalt { get; set; }

    public string LeaveCompOffDates { get; set; } = null!;

    public byte HalfPayment { get; set; }

    public int? HalfPaid { get; set; }

    public byte WarningFlag { get; set; }

    public byte RulesViolate { get; set; }

    public decimal? VerticalId { get; set; }

    public decimal? SubVerticalId { get; set; }

    public string? DeptName { get; set; }

    public byte? MCancelWoHo { get; set; }

    public string? Gender { get; set; }
}
