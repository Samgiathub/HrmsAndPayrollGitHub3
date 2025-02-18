using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0120LeaveFinalNLevelApprovalBackupMehul04062022
{
    public decimal? RowId { get; set; }

    public string? LeaveName { get; set; }

    public string? ApplicationCode { get; set; }

    public decimal? EmpId { get; set; }

    public decimal? EmpCode { get; set; }

    public string? EmpFullName { get; set; }

    public string? SEmpFullName { get; set; }

    public decimal? CmpId { get; set; }

    public string ApprovalStatus { get; set; } = null!;

    public decimal? LeaveApplicationId { get; set; }

    public decimal? LeaveApprovalId { get; set; }

    public DateTime? FromDate { get; set; }

    public DateTime? ToDate { get; set; }

    public decimal? LeavePeriod { get; set; }

    public string? AlphaEmpCode { get; set; }

    public decimal? LeaveId { get; set; }

    public string? LeaveReason { get; set; }

    public string? ApprovalComments { get; set; }

    public DateTime? ApprovalDate { get; set; }

    public string? LeaveAssignAs { get; set; }

    public int IsFinalApproved { get; set; }

    public decimal? SEmpIdA { get; set; }

    public int? ApplyHourly { get; set; }

    public string? EmpFirstName { get; set; }

    public decimal? BranchId { get; set; }

    public decimal? DeptId { get; set; }

    public string? DefaultShortName { get; set; }

    public string? LeaveAppDoc { get; set; }

    public string IsBackdatedApplication { get; set; } = null!;

    public byte? HalfPayment { get; set; }

    public string NightHalt { get; set; } = null!;

    public string? LeaveType { get; set; }

    public DateTime? LeaveInTime { get; set; }

    public DateTime? LeaveOutTime { get; set; }

    public decimal? ResponsibleEmpId { get; set; }

    public DateTime? HalfLeaveDate { get; set; }

    public byte? RulesViolate { get; set; }

    public byte? MCancelWoHo { get; set; }

    public DateTime? ApplicationDate { get; set; }

    public string? ResponsibleEmployee { get; set; }
}
