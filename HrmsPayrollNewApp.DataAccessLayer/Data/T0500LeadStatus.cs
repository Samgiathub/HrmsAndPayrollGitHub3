using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0500LeadStatus
{
    public decimal LeadStatusId { get; set; }

    public string? LeadStatusName { get; set; }

    public decimal? CmpId { get; set; }
}
