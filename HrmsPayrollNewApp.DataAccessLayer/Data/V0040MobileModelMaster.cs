using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0040MobileModelMaster
{
    public decimal MobileCatId { get; set; }

    public string? MobileCompanyName { get; set; }

    public string? MobileCatName { get; set; }

    public DateTime? EffectiveDate { get; set; }

    public decimal CmpId { get; set; }

    public byte? SaleActive { get; set; }

    public byte? StockActive { get; set; }

    public byte IsActive { get; set; }

    public decimal? ParentCategoryId { get; set; }
}
