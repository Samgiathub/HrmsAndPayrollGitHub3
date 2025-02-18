using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0090HrmsAssetAllocation
{
    public decimal AssetApprovalId { get; set; }

    public decimal ResumeId { get; set; }

    public decimal CmpId { get; set; }

    public decimal AssetId { get; set; }

    public decimal BrandId { get; set; }

    public string ModelName { get; set; } = null!;

    public DateTime AllocationDate { get; set; }

    public DateTime PurchaseDate { get; set; }

    public decimal AssetMId { get; set; }

    public string AssetCode { get; set; } = null!;

    public DateTime? InstallmentDate { get; set; }

    public decimal? InstallmentAmount { get; set; }

    public decimal? IssueAmount { get; set; }

    public string? DeductionType { get; set; }

    public string? SerialNo { get; set; }

    public virtual T0040AssetDetail AssetM { get; set; } = null!;

    public virtual T0055ResumeMaster Resume { get; set; } = null!;

    public virtual ICollection<T0090HrmsAssetInstallationDetail> T0090HrmsAssetInstallationDetails { get; set; } = new List<T0090HrmsAssetInstallationDetail>();
}
