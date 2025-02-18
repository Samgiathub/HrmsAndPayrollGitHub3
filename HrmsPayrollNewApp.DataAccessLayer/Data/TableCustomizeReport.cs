using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class TableCustomizeReport
{
    public decimal CustId { get; set; }

    public string CustFiledName { get; set; } = null!;
}
