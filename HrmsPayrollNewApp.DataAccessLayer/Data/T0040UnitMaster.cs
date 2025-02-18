using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0040UnitMaster
{
    public decimal UnitId { get; set; }

    public decimal? CmpId { get; set; }

    public decimal? LoginId { get; set; }

    public string? UnitName { get; set; }

    public DateTime? SystemDate { get; set; }
}
