using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0040UnitTypeMaster
{
    public int UnitTypeId { get; set; }

    public int? CmpId { get; set; }

    public string? UnitTypeName { get; set; }

    public DateTime? SystemDate { get; set; }
}
