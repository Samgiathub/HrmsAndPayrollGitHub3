using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0040UnitsMaster
{
    public int UnitTypeId { get; set; }

    public string? UnitName { get; set; }

    public string? UnitTypeName { get; set; }

    public int? CmpId { get; set; }

    public int UnitId { get; set; }
}
