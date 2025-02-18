using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0000OtHrsCnv
{
    public decimal OtActualHrs { get; set; }

    public decimal For25BelowDay { get; set; }

    public decimal For25BelowHrs { get; set; }

    public decimal For25AboveHrs { get; set; }
}
