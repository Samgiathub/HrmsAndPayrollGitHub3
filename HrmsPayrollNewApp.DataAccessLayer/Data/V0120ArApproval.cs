using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0120ArApproval
{
    public decimal ArAprId { get; set; }

    public decimal? ArAppId { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public decimal IncrementId { get; set; }

    public DateTime ForDate { get; set; }

    public decimal? EligibilityAmount { get; set; }

    public decimal? TotalAmount { get; set; }

    public decimal AprStatus { get; set; }

    public decimal CreatedBy { get; set; }

    public DateTime DateCreated { get; set; }

    public decimal? ModifiedBy { get; set; }

    public DateTime? DateModified { get; set; }

    public string? EmpFullNameNew { get; set; }

    public decimal? BranchId { get; set; }

    public string EmpFirstName { get; set; } = null!;

    public string? AlphaEmpCode { get; set; }
}
