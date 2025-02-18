using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0090HrmsAssetInstallationDetail
{
    public decimal AssetInstallationDetId { get; set; }

    public decimal CmpId { get; set; }

    public decimal AssetMId { get; set; }

    public decimal AssetInstallationId { get; set; }

    public string InstallationDetails { get; set; } = null!;

    public decimal ResumeId { get; set; }

    public decimal AssetApprovalId { get; set; }

    public virtual T0090HrmsAssetAllocation AssetApproval { get; set; } = null!;

    public virtual T0030AssetInstallation AssetInstallation { get; set; } = null!;

    public virtual T0040AssetDetail AssetM { get; set; } = null!;

    public virtual T0055ResumeMaster Resume { get; set; } = null!;
}
