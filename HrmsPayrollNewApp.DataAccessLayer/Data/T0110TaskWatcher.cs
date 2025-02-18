using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0110TaskWatcher
{
    public int TaskWatcherId { get; set; }

    public int? TaskId { get; set; }

    public int? EmpId { get; set; }
}
