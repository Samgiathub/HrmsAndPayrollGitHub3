using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class ViewLateEmp
{
    public decimal IoTranId { get; set; }

    public decimal EmpId { get; set; }

    public DateTime ForDate { get; set; }

    public DateTime? InTime { get; set; }

    public string? Reason { get; set; }

    public decimal CmpId { get; set; }

    public decimal BranchId { get; set; }

    public decimal? SubBranchId { get; set; }

    public string? BranchName { get; set; }

    public decimal GrdId { get; set; }

    public decimal? DeptId { get; set; }

    public decimal? DesigId { get; set; }

    public decimal? TypeId { get; set; }

    public decimal EmpCode { get; set; }

    public string? EmpFullName { get; set; }

    public string? AlphaEmpCode { get; set; }

    public string? AlphaCode { get; set; }

    public decimal? EmpSuperior { get; set; }

    public byte ChkBySuperior { get; set; }

    public string? HalfFullDay { get; set; }

    public string? SupComment { get; set; }

    public string? EmpName { get; set; }

    public byte IsCancelLateIn { get; set; }

    public byte IsCancelEarlyOut { get; set; }

    public DateTime? OutTime { get; set; }

    public string? Superior { get; set; }

    public string? SuperiorCode { get; set; }

    public DateTime? AppDate { get; set; }

    public string? OtherReason { get; set; }

    public decimal? VerticalId { get; set; }

    public decimal? SubVerticalId { get; set; }

    public DateTime? ActualInTime { get; set; }

    public DateTime? ActualOutTime { get; set; }

    public string? ShiftEndTime { get; set; }

    public string? ShiftStTime { get; set; }
}
