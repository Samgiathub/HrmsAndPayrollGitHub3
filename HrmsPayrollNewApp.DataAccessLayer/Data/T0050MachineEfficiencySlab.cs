using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0050MachineEfficiencySlab
{
    public decimal SlabId { get; set; }

    public decimal? CmpId { get; set; }

    public decimal? EfficiencyId { get; set; }

    public decimal AvgPercent { get; set; }

    public decimal BasicAmount { get; set; }
}
