using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0100ClaimApplicationNewPayment
{
    public decimal ClaimAppId { get; set; }

    public decimal CmpId { get; set; }

    public decimal ClaimId { get; set; }

    public DateTime ClaimAppDate { get; set; }

    public string ClaimAppCode { get; set; } = null!;

    public decimal ClaimAppAmount { get; set; }

    public string ClaimAppDescription { get; set; } = null!;

    public string ClaimAppDoc { get; set; } = null!;

    public string? ClaimAppStatus { get; set; }

    public string ClaimName { get; set; } = null!;

    public decimal EmpId { get; set; }

    public string? EmpFullName { get; set; }

    public decimal ClaimMaxLimit { get; set; }

    public string? EmpFirstName { get; set; }

    public string? MobileNo { get; set; }

    public string? OtherEmail { get; set; }

    public decimal BranchId { get; set; }

    public decimal? EmpCode { get; set; }

    public string? SEmpName { get; set; }

    public decimal? SEmpId { get; set; }

    public string? EmpFullNameNew { get; set; }

    public string? AlphaEmpCode { get; set; }

    public string? Supervisor { get; set; }

    public decimal? DesigId { get; set; }

    public decimal? VerticalId { get; set; }

    public decimal? SubverticalId { get; set; }

    public string DraftStatus { get; set; } = null!;

    public byte SubmitFlag { get; set; }

    public decimal? DeptId { get; set; }

    public decimal GrdId { get; set; }

    public decimal ClaimAprId { get; set; }

    public decimal? ClaimAprDeductFromSal { get; set; }
}
