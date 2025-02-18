using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0030AssetInstallation
{
    public decimal AssetInstallationId { get; set; }

    public decimal CmpId { get; set; }

    public decimal AssetId { get; set; }

    public string InstallationName { get; set; } = null!;

    public decimal? InstallationType { get; set; }

    public virtual T0040AssetMaster Asset { get; set; } = null!;

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual ICollection<T0090HrmsAssetInstallationDetail> T0090HrmsAssetInstallationDetails { get; set; } = new List<T0090HrmsAssetInstallationDetail>();

    public virtual ICollection<T0110AssetInstallationDetail> T0110AssetInstallationDetails { get; set; } = new List<T0110AssetInstallationDetail>();

    public virtual ICollection<T0110AssetTitleDetail> T0110AssetTitleDetails { get; set; } = new List<T0110AssetTitleDetail>();
}
