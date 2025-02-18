using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0040CityCategoryMaster
{
    public decimal CityCatId { get; set; }

    public decimal CityId { get; set; }

    public string CityCatName { get; set; } = null!;

    public decimal CmpId { get; set; }

    public string? Remarks { get; set; }
}
