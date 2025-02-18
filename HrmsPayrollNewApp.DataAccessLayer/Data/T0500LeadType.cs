using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0500LeadType
{
    public decimal LeadTypeId { get; set; }

    public string? LeadTypeName { get; set; }

    public decimal? CmpId { get; set; }
}
