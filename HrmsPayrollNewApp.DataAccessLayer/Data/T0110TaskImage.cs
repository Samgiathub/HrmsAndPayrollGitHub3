using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0110TaskImage
{
    public int TaskImageId { get; set; }

    public int? TaskId { get; set; }

    public string? TaskFileName { get; set; }

    public string? TaskFileNameStr { get; set; }
}
