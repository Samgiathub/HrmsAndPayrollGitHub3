using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class GetSkillcategory
{
    public decimal? SubCatId { get; set; }

    public string? SubCatCode { get; set; }

    public string? SubCatName { get; set; }

    public string? CatName { get; set; }

    public decimal? CatId { get; set; }

    public decimal? CmpId { get; set; }
}
