using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class ViewAttendanceFinalNLevelApproval
{
    public decimal IoTranId { get; set; }

    public decimal EmpId { get; set; }

    public DateTime ForDate { get; set; }

    public DateTime? InTime { get; set; }

    public string? Reason { get; set; }

    public decimal CmpId { get; set; }

    public decimal BranchId { get; set; }

    public DateTime? AppDate { get; set; }

    public decimal EmpCode { get; set; }

    public string? EmpFullName { get; set; }

    public string? AlphaEmpCode { get; set; }

    public string? AlphaCode { get; set; }

    public byte? ChkBySuperior { get; set; }

    public string? HalfFullDay { get; set; }

    public string? SupComment { get; set; }

    public string? EmpName { get; set; }

    public byte IsCancelLateIn { get; set; }

    public byte IsCancelEarlyOut { get; set; }

    public DateTime? OutTime { get; set; }

    public string? Superior { get; set; }

    public decimal? SEmpIdA { get; set; }

    public string? OtherReason { get; set; }

    public DateTime? ActualInTime { get; set; }

    public DateTime? ActualOutTime { get; set; }
}
