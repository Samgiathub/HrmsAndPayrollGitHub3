using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0050LateMarkRateDesignation
{
    public decimal TranId { get; set; }

    public decimal GenId { get; set; }

    public decimal CmpId { get; set; }

    public decimal DesigId { get; set; }

    public decimal NormalRate { get; set; }

    public decimal LunchRate { get; set; }
}
