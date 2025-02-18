using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0500LeadProduct
{
    public decimal LeadProductId { get; set; }

    public string? LeadProductName { get; set; }

    public decimal? CmpId { get; set; }
}
