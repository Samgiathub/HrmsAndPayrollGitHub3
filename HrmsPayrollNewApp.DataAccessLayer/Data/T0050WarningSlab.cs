using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0050WarningSlab
{
    public decimal SlabId { get; set; }

    public decimal CmpId { get; set; }

    public decimal WarningId { get; set; }

    public decimal FromHours { get; set; }

    public decimal ToHours { get; set; }

    public decimal DeductDays { get; set; }
}
