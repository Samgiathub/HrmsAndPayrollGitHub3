using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0040VendorMaster
{
    public decimal VendorId { get; set; }

    public string VendorName { get; set; } = null!;

    public string? Address { get; set; }

    public string? City { get; set; }

    public string? ContactPerson { get; set; }

    public string? ContactNumber { get; set; }

    public decimal? CmpId { get; set; }
}
