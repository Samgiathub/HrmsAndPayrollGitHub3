using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0040TaskCategoryMaster
{
    public int TaskCatId { get; set; }

    public string? TcCode { get; set; }

    public string? TcTitle { get; set; }

    public int? TcStatus { get; set; }

    public DateTime? TcCreatedDate { get; set; }

    public DateTime? TcUpdatedDate { get; set; }
}
