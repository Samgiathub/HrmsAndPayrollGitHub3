using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0040AssetDetailsReport
{
    public string Vendor { get; set; } = null!;

    public string? VendorAddress { get; set; }

    public string? City { get; set; }

    public string? Pono { get; set; }

    public string? InvoiceNo { get; set; }

    public DateTime? InvoiceDate { get; set; }

    public DateTime? PonoDate { get; set; }

    public string InstallationDetails { get; set; } = null!;
}
