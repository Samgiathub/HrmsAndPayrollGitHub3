using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0030ThanaMaster
{
    public decimal ThanaId { get; set; }

    public decimal? CmpId { get; set; }

    public string ThanaName { get; set; } = null!;
}
