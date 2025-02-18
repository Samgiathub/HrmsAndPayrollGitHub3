using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0130ArApprovalDetail
{
    public decimal ArAprDetaillId { get; set; }

    public decimal? ArAppId { get; set; }

    public decimal ArAprId { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public decimal? IncrementId { get; set; }

    public DateTime ForDate { get; set; }

    public decimal AdId { get; set; }

    public string AdFlag { get; set; } = null!;

    public string? AdMode { get; set; }

    public decimal? AdPercentage { get; set; }

    public decimal? AdAmount { get; set; }

    public decimal? EAdMaxLimit { get; set; }

    public string? Comments { get; set; }

    public decimal CreatedBy { get; set; }

    public DateTime DateCreated { get; set; }

    public decimal? Modifiedby { get; set; }

    public DateTime? DateModified { get; set; }

    public virtual T0050AdMaster Ad { get; set; } = null!;

    public virtual T0100ArApplication? ArApp { get; set; }

    public virtual T0120ArApproval ArApr { get; set; } = null!;

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;
}
