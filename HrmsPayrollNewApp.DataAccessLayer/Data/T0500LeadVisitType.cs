using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0500LeadVisitType
{
    public decimal VisitTypeId { get; set; }

    public string? VisitTypeName { get; set; }

    public decimal? CmpId { get; set; }
}
