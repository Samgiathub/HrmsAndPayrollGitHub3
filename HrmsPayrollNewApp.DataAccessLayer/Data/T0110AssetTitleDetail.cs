using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0110AssetTitleDetail
{
    public decimal AssetTitleId { get; set; }

    public decimal CmpId { get; set; }

    public decimal AssetInstallationId { get; set; }

    public string AssetTitle { get; set; } = null!;

    public decimal? AssetMId { get; set; }

    public virtual T0030AssetInstallation AssetInstallation { get; set; } = null!;

    public virtual T0040AssetDetail? AssetM { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;
}
