using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0040MoodActivityMaster
{
    public int MoodActivityId { get; set; }

    public string? Activity { get; set; }

    public DateTime? SystemDate { get; set; }

    public string? SelectedImageName { get; set; }

    public string? UnselectedImageName { get; set; }
}
