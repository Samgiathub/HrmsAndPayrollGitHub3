using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0090SuperiorClaimApproval
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

    public string? ClaimName { get; set; }

    public decimal EmpId { get; set; }

    public string? EmpFullName { get; set; }

    public decimal? ClaimMaxLimit { get; set; }

    public string? EmpFirstName { get; set; }

    public string? MobileNo { get; set; }

    public string? OtherEmail { get; set; }

    public decimal BranchId { get; set; }

    public decimal? EmpCode { get; set; }

    public decimal? EmpSuperior { get; set; }

    public decimal? REmpId { get; set; }
}
