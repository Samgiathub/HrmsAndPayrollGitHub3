using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0040UnitsMaster
{
    public int UnitId { get; set; }

    public int? CmpId { get; set; }

    public int? UnitTypeId { get; set; }

    public string? UnitName { get; set; }

    public DateTime? SystemDate { get; set; }
}
