using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class Category
{
    public int CatId { get; set; }

    public string? CategoryName { get; set; }

    public string? Descriptions { get; set; }
}
