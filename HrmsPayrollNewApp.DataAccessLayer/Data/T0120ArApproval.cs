using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0120ArApproval
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

    public virtual T0100ArApplication? ArApp { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0080EmpMaster Emp { get; set; } = null!;

    public virtual T0095Increment Increment { get; set; } = null!;

    public virtual ICollection<T0130ArApprovalDetail> T0130ArApprovalDetails { get; set; } = new List<T0130ArApprovalDetail>();
}
