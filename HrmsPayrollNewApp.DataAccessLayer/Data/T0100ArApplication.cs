using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0100ArApplication
{
    public decimal ArAppId { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public decimal GrdId { get; set; }

    public DateTime ForDate { get; set; }

    public decimal? EligibileAmount { get; set; }

    public decimal? TotalAmount { get; set; }

    public decimal? AppStatus { get; set; }

    public decimal CreatedBy { get; set; }

    public DateTime DateCreated { get; set; }

    public decimal? Modifiedby { get; set; }

    public DateTime? DateModified { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0080EmpMaster Emp { get; set; } = null!;

    public virtual T0040GradeMaster Grd { get; set; } = null!;

    public virtual ICollection<T0100ArApplicationDetail> T0100ArApplicationDetails { get; set; } = new List<T0100ArApplicationDetail>();

    public virtual ICollection<T0120ArApproval> T0120ArApprovals { get; set; } = new List<T0120ArApproval>();

    public virtual ICollection<T0130ArApprovalDetail> T0130ArApprovalDetails { get; set; } = new List<T0130ArApprovalDetail>();
}
