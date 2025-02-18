using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class VersionControl
{
    public int VersionId { get; set; }

    public string? VersionName { get; set; }

    public string? VersionType { get; set; }

    public string? VersionDescription { get; set; }

    public DateTime? VersionReleaseDate { get; set; }

    public string? VersionCode { get; set; }
}
