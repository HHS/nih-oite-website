---
name: Blog Headlines (homepage)
---

<div class="grid-container" markdown="1">

---

## Blog

{::blogs count="3"}
<ul class="usa-card-group">
  <% headlines.each do |headline| %>
    <li class="usa-card tablet:grid-col">
      <div class="usa-card__container">
        <div class="usa-card__header">
          <h3 class="usa-card__heading"><a href="<%= headline.url %>"><%= headline.title %></a></h3>
        </div>
        <div class="usa-card__body overflow-hidden">
          <p><%= headline.blurb %></p>
        </div>
      </div>
    </li>
  <% end %>
</ul>
{:/blogs}

[Subscribe to the OITE careers blog](https://oitecareersblog.od.nih.gov/)

</div>
