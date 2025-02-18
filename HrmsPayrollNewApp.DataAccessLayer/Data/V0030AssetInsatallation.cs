using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0030AssetInsatallation
{
    public decimal AssetInstallationId { get; set; }

    public decimal CmpId { get; set; }

    public decimal AssetId { get; set; }

    public string InstallationName { get; set; } = null!;

    public string AssetName { get; set; } = null!;

    public decimal? InstallationType { get; set; }

    public string Type { get; set; } = null!;
}
