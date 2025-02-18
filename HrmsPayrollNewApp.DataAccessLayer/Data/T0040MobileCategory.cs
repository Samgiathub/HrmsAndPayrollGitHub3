using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0040MobileCategory
{
    public decimal MobileCatId { get; set; }

    public decimal CmpId { get; set; }

    public string? MobileCatName { get; set; }

    public decimal? ParentCategoryId { get; set; }

    public DateTime? SystemDate { get; set; }

    public decimal? LoginId { get; set; }

    public byte IsActive { get; set; }

    public DateTime EffectiveDate { get; set; }

    public byte? SaleActive { get; set; }

    public byte? StockActive { get; set; }
}
