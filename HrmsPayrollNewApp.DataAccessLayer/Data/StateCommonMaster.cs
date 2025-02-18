using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class StateCommonMaster
{
    public int Id { get; set; }

    public string State { get; set; } = null!;

    public string District { get; set; } = null!;

    public string StateType { get; set; } = null!;
}
